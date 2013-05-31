From: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>
Subject: Re: Another try at getting pktgen to work with wifi.
Date: Fri, 31 May 2013 16:51:17 -0400
Message-ID: <20130531205117.GA27551@localhost>
References: <51A79E4A.7000609@candelatech.com>
 <51A7B049.9090201@openwrt.org>
 <51A7BA63.4080403@candelatech.com>
 <51A857BF.7070008@openwrt.org>
 <51A8DC1C.1040908@candelatech.com>
 <1370021846.14117.13.camel@jlt4.sipsolutions.net>
 <51A8E53E.8030101@candelatech.com>
 <1370025698.14117.15.camel@jlt4.sipsolutions.net>
 <51A8F141.5050804@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51A8F141.5050804-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, May 31, 2013 at 11:51:45AM -0700, Ben Greear wrote:
> cfg80211_classify8021d uses it to determine the queue in if skb->priority is
> set to a special range (hard coded un-documented hack from hell, it appears).
> 
> I didn't go looking to find out where those magic values might be set.

Actually, this hard coded hack from hell is documented :)

http://wireless.kernel.org/en/developers/Documentation/mac80211/queues?highlight=%28so_priority%29

-- 
Bob Copeland %% www.bobcopeland.com
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
