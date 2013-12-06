From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [GIT PULL] xhci: Regression fix for 3.13.
Date: Fri, 6 Dec 2013 15:28:42 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B746A@saturn3.aculab.com>
References: <cover.1386017042.git.sarah.a.sharp@linux.intel.com> <20131202214205.GA26175@kroah.com> <52A166CB.4020508@pobox.com> <20131206152512.GA23212@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Sarah Sharp" <sarah.a.sharp@linux.intel.com>,
	<linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	"Mark Lord" <mlord@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44057 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752709Ab3LFP32 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 10:29:28 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 27916-05 for <netdev@vger.kernel.org>;
 Fri,  6 Dec 2013 15:29:26 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131206152512.GA23212@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Greg Kroah-Hartman [mailto:gregkh@linuxfoundation.org]
> On Fri, Dec 06, 2013 at 12:55:23AM -0500, Mark Lord wrote:
> > On 13-12-02 04:42 PM, Greg Kroah-Hartman wrote:
> > > On Mon, Dec 02, 2013 at 12:49:08PM -0800, Sarah Sharp wrote:
> > >> The following changes since commit c24cb6c8b501ebdf1aacec7960110a9741a45ced:
> > >>
> > >>   Merge tag 'fixes-for-v3.13-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/balbi/usb into
> usb-linus (2013-11-27 09:49:03 -0800)
> > >>
> > >> are available in the git repository at:
> > >>
> > >>
> > >>   git://git.kernel.org/pub/scm/linux/kernel/git/sarah/xhci.git tags/for-usb-linus-2013-12-02
> > >
> > > Pulled and pushed out, thanks.
> >
> > Did this commit make it into linux-3.12.3 ?
> 
> There's this cool tool called 'git' where you can look these things
> up... :)

If you are really desperate to find what is in a specific kernel use
objdump -d.

	David
