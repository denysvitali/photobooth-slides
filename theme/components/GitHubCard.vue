<template>
    <div class="github-card">
        <div class="github-card-header">
            <div class="header-background">
                <div class="pattern-overlay"></div>
            </div>
            <logos-github class="github-logo"/>
            <div class="top-part">
                <div class="avatar-container">
                    <img :src="user.avatar_url" alt="Profile" class="avatar" />
                    <div class="avatar-ring"></div>
                </div>
                <div class="user-info">
                    <h2 class="name">{{ user.name || user.login }}</h2>
                    <h3 class="username">
                        <a :href="`https://github.com/${user.login}`" target="_blank" rel="noopener noreferrer">@{{ user.login }}</a>
                    </h3>
                    <p class="bio" v-if="user.bio">{{ user.bio }}</p>
                    <div class="user-details" v-if="user.location || user.blog">
                        <p v-if="user.location" class="location">
                            <mdi-location class="detail-icon"/> 
                            <span>{{ user.location }}</span>
                        </p>
                        <p v-if="user.blog" class="website">
                            <mdi-web class="detail-icon"/> 
                            <a :href="formatBlogUrl(user.blog)" target="_blank" rel="noopener noreferrer">{{ user.blog }}</a>
                        </p>
                    </div>
                </div>
            </div>
        </div>
        <div class="github-card-stats">
            <div class="stat">
                <mdi-book class="stat-icon"/>
                <span class="stat-value">{{ user.public_repos }}</span>
                <span class="stat-label">Repos</span>
            </div>
            <div class="stat">
                <mdi-people class="stat-icon"/>
                <span class="stat-value">{{ formatNumber(user.followers) }}</span>
                <span class="stat-label">Followers</span>
            </div>
            <div class="stat">
                <mdi-account-multiple class="stat-icon"/>
                <span class="stat-value">{{ formatNumber(user.following) }}</span>
                <span class="stat-label">Following</span>
            </div>
            <div class="stat">
                <mdi-calendar-clock class="stat-icon"/>
                <span class="stat-value">{{ accountAge }}</span>
                <span class="stat-label">Years</span>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: 'GitHubCard',
    props: {
        username: {
            type: String,
            required: true
        }
    },
    data() {
        return {
            user: {
                name: '',
                login: '',
                avatar_url: '',
                bio: '',
                location: '',
                blog: '',
                public_repos: 0,
                followers: 0,
                following: 0,
                created_at: '',
                public_gists: 0
            },
            stars: 0,
            gists: 0,
            loading: true,
            error: null
        }
    },
    computed: {
        accountAge() {
            if (!this.user.created_at) return 0;
            const createdDate = new Date(this.user.created_at);
            const currentDate = new Date();
            const diffYears = (currentDate - createdDate) / (1000 * 60 * 60 * 24 * 365.25);
            return Math.floor(diffYears);
        }
    },
    mounted() {
        this.fetchGitHubData()
    },
    methods: {
        async fetchGitHubData() {
            try {
                // Fetch user data
                const userResponse = await fetch(`https://api.github.com/users/${this.username}`)
                if (!userResponse.ok) {
                    throw new Error('Failed to fetch user data')
                }
                this.user = await userResponse.json()
            } catch (error) {
                this.error = error.message
                console.error('Error fetching GitHub data:', error)
            } finally {
                this.loading = false
            }
        },
        formatBlogUrl(url) {
            if (!url) return '';
            return url.startsWith('http') ? url : `https://${url}`;
        },
        formatNumber(num) {
            if (num >= 1000) {
                return (num / 1000).toFixed(1) + 'k';
            }
            return num;
        }
    }
}
</script>

<style>
.github-logo path {
    fill: #fff;
}
</style>

<style scoped>
.github-card {
    background: #fff;
    border-radius: 16px;
    box-shadow: 
        0 10px 30px rgba(0, 0, 0, 0.1),
        0 1px 3px rgba(0, 0, 0, 0.05),
        0 20px 40px rgba(0, 0, 0, 0.2);
    
    overflow: hidden;
    max-width: 400px;
    margin: 0 auto;
    font-size: 15px;
    transform: translateY(0);
    transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
    border: 1px solid rgba(255, 255, 255, 0.1);
    position: relative;
}

.github-card-stats .slidev-icon {
    color: #333;
    transition: transform 0.3s ease, color 0.3s ease;
}

.header-background {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: linear-gradient(145deg, #2a3c4f 0%, #09121b 100%);
    overflow: hidden;
}

.github-card-header {
    padding: 24px 24px;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    color: white;
    position: relative;
    overflow: hidden;
}

.github-card-header .github-logo {
    margin-bottom: 18px;
    height: 25px;
    filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.3));
    transition: transform 0.3s ease;
}

.github-card-header .top-part {
    display: flex;
    flex-direction: row;
    align-items: flex-start;
    width: 100%;
    position: relative;
    z-index: 1;
}

.avatar-container {
    margin-right: 18px;
    flex-shrink: 0;
    position: relative;
}

.avatar {
    width: 85px;
    height: 85px;
    border-radius: 50%;
    box-shadow: 0 1px 8px rgba(0, 0, 0, 0.3);
    object-fit: cover;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
    background-color: #fff;
}

.avatar-ring {
    position: absolute;
    top: -4px;
    left: -4px;
    right: -4px;
    bottom: -4px;
    border-radius: 50%;
    pointer-events: none;
}

.user-info {
    flex-grow: 1;
    overflow: hidden;
}

.name {
    margin: 0 0;
    font-size: 1.4em;
    font-weight: 600;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.username {
    margin: -4px 0 10px;
    font-size: 1em;
    font-weight: 400;
    opacity: 0.9;
}

.username a {
    color: #58a6ff;
    text-decoration: none;
    transition: color 0.2s ease, text-shadow 0.2s ease;
}

.bio {
    margin: 5px 0 0;
    font-size: 0.9em;
    line-height: 1.5;
    opacity: 0.92;
    max-height: 4.5em;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: 3;
    -webkit-box-orient: vertical;
}

.user-details {
    margin-top: 12px;
    font-size: 0.9em;
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.location, .website {
    display: flex;
    align-items: center;
    gap: 8px;
    margin: 0;
    opacity: 0.9;
    transition: opacity 0.2s ease;
}

.detail-icon {
    font-size: 1.1em;
    opacity: 0.85;
}

.website a {
    color: #58a6ff;
    text-decoration: none;
    transition: color 0.2s ease;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 220px;
    display: inline-block;
}

.github-card-stats {
    display: flex;
    justify-content: space-around;
    flex-wrap: wrap;
    padding: 18px 12px;
    background: #f6f8fa;
    background-image: linear-gradient(to bottom, #f8fafc, #f1f5f9);
    border-top: 1px solid rgba(0, 0, 0, 0.06);
}

.stat {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 12px 8px;
    flex: 1;
    min-width: 70px;
    border-radius: 8px;
    transition: background-color 0.2s ease, transform 0.2s ease;
    cursor: default;
}

.stat-icon {
    font-size: 1.3em;
    color: #444;
    margin-bottom: 6px;
    transition: transform 0.3s ease;
}

.stat-value {
    font-size: 1.5em;
    font-weight: 600;
    color: #24292e;
    line-height: 1.2;
    transition: color 0.2s ease;
}

.stat-label {
    font-size: 0.85em;
    color: #57606a;
    margin-top: 4px;
    font-weight: 500;
}

</style>
