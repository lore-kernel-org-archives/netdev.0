From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 3/14][TUN]: Introduce the tun_net structure.
Date: Tue, 15 Apr 2008 03:06:34 -0700 (PDT)
Message-ID: <20080415.030634.98977256.davem@davemloft.net>
References: <47FE2CF0.6080100@openvz.org>
	<20080415.004417.172551569.davem@davemloft.net>
	<48048411.5030506@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org,
        den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48048411.5030506-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Date: Tue, 15 Apr 2008 14:31:45 +0400

> Are you willing to look at vlans and ip tunnels (ipip, gre, sit) as 
> well? This will be 6 sets ~7 patches each.

Sure.
