From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: Fw: [Kernel-janitors] old ioctl definitions in 2.5
Date: Tue, 16 Sep 2003 16:31:48 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309161631.48653.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A02A464A9@hasmsx403.iil.intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <rddunlap@osdl.org>, <netdev@oss.sgi.com>, <janitor@sternwelten.at>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jay Vosburgh" <fubar@us.ibm.com>, "David S. Miller" <davem@redhat.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A02A464A9@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 16 September 2003 04:11 am, Jay Vosburgh wrote:
> >On Mon, 15 Sep 2003 16:57:26 -0700
> >
> >Jay Vosburgh <fubar@us.ibm.com> wrote:
> >>      My only concern is a matter of timing; we're right at the
> >> end of synchronizing the 2.4 and 2.6 bonding sources.  Once
> >> that's settled (hopefully in a few days, the last patch set for
> >> 2.4 came in this morning), then removing them from that header
> >> and the bonding code should be fine.
> >
> >No problem.  Just push the change to Jeff then after you're
> >done merging stuff around, ok?
>
>         Will do.

I'm on the verge of finishing my cleanup set re-do. Now that Amir sent 
all the synching stuff, I could put that one in as well, and it would 
fit on both 2.4 and 2.6.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
