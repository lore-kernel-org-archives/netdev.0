From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: eepro100 - 802.1q - mtu size
Date: Fri, 17 Jan 2003 17:27:19 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030117172719.GA31343@codemonkey.org.uk>
References: <20030117145357.GA1139@paradigm.rfc822.org> <20030117160840.GR12676@stingr.net> <20030117162818.GA1074@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Florian Lohoff <flo@rfc822.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20030117162818.GA1074@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jan 17, 2003 at 11:28:18AM -0500, Jeff Garzik wrote:

 > The reason why the patch was not accepted is that it changes one magic
 > number to another magic number, and without chipset docs, I had no idea
 > what either magic number really meant.

Whilst on the subject of magic numbers in net drivers, did we ever get
to the bottom of 2.4's ChangeSet 1.587.9.20 

ftp://ftp.kernel.org/pub/linux/kernel/people/davej/patches/2.5/2.5.48/split-dj1/net-cs89x0-media-corrections.diff

?

		Dave

-- 
| Dave Jones.        http://www.codemonkey.org.uk
| SuSE Labs
