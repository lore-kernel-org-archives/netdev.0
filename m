From: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>
Subject: Re: [RFCv2 0/3] mac80211: implement fq codel
Date: Wed, 16 Mar 2016 14:55:31 -0400
Message-ID: <20160316185531.GA1771@localhost>
References: <1458123478-1795-1-git-send-email-michal.kazior@tieto.com>
 <CA+BoTQ=65mHN5iLnZjTE+tyEG7nfmCx4NZNbGRF6+VpRaNmOYw@mail.gmail.com>
 <CAA93jw5cUaj_qM+CYHHoRaghLDLC+BUgF4AjT=Oec+SB-zb74g@mail.gmail.com>
 <CAA93jw6tDdiYuginPbUY1DFJLiDxofHMFN6j2BvQPabPmBtuRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	make-wifi-fast-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org,
	"codel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org" <codel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
To: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAA93jw6tDdiYuginPbUY1DFJLiDxofHMFN6j2BvQPabPmBtuRw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 16, 2016 at 11:36:31AM -0700, Dave Taht wrote:
> That is the sanest 802.11e queue behavior I have ever seen!  (at both
> 6 and 300mbit! in the ath10k patched mac test)

Out of curiosity, why does BE have larger latency than BK in that chart?
I'd have expected the opposite.

-- 
Bob Copeland %% http://bobcopeland.com/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
