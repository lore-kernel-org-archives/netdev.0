From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: [Bonding-announce] [PATCH SET][bonding] cleanup
Date: Thu, 25 Sep 2003 20:11:53 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309252011.53960.shmulik.hen@intel.com>
References: <200309251549.59177.shmulik.hen@intel.com> <20030925164719.GA45241@calma.pair.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: bonding-devel@lists.sourceforge.net,
        bonding-announce@lists.sourceforge.net, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
        Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>,
        "Noam, Amir" <amir.noam@intel.com>,
        "Mendelson, Tsippy" <tsippy.mendelson@intel.com>,
        "Noam, Marom" <noam.marom@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Chad N. Tindel" <chad@tindel.net>
In-Reply-To: <20030925164719.GA45241@calma.pair.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 25 September 2003 07:47 pm, Chad N. Tindel wrote:
> > patch 4 - remove dead code, old compatibility stuff and redundant
> >           checks.
>
> I'm a bit concerned about doing some of this stuff in the 2.4
> series.  That compatibility stuff is there for a reason, and was
> set to be removed in 2.6.  Perhaps we shouldn't be doing stuff this
> drastic until 2.6 because of the risk of breaking users.

That's the word I got from Jay in response to the " [Kernel-janitors] 
old ioctl definitions in 2.5" thread.

>Jay Vosburgh <fubar@us.ibm.com> wrote:
>	I was going to add it on to the end of the clean up set, but
> if you want to do it, go ahead.  Nobody seems to have objected to
> removing the _OLD stuff, which I view as a good thing.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
