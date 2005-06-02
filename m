From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] ieee80211: Update generic definitions to latest specs.
Date: Thu, 2 Jun 2005 18:50:38 +0200
Message-ID: <20050602185038.4fd9dafb@griffin.suse.cz>
References: <429E1FAB.6080503@home.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, jbohac@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Gertjan van Wingerde <gwingerde@home.nl>
In-Reply-To: <429E1FAB.6080503@home.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 01 Jun 2005 22:50:51 +0200, Gertjan van Wingerde wrote:
> +#define WLAN_STATUS_ASSOC_DENIED_SPECTRUM_MGMT_REQUIRED 22
> +#define WLAN_STATUS_ASSOC_REJECTED_POWER_CAP_UNACCEPTABLE 23
> +#define WLAN_STATUS_ASSOC_REJECTED_SUPP_CHANNELS_UNACCEPTABLE 24
> (...)
> +/* 802.11h */
> +#define WLAN_REASON_DISASSOC_POWER_CAP_UNACCEPTABLE 10
> +#define WLAN_REASON_DISASSOC_SUPP_CHANNELS_UNACCEPTABLE 11

Aren't these identifiers a bit too long? It seems to be unpractical to use
them.


-- 
Jiri Benc
SUSE Labs
