From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [RFR] new e100 driver
Date: Fri, 5 Dec 2003 14:01:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102229B19@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>,
        "Rask Ingemann Lambertsen" <rask@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > I would be nice if the documentation said so. A few days 
> > ago I spent half an hour or so trying to figure out why frames
> > sent by an 82558 were padded with 0x00 rather than the
> > documented 0x7e (with no sign of skb_padto(), memset() or
> > anything similiar in the driver).
> 
> Do you mean the PDF documentation?  I dunno how much control Scott 
> Feldman and his team have over that.

Sorry Rask.  It'll be easier to accumulate several doc changes and roll
them out at one time.  Do you have other doc updates?  I'll try to
maintain a list for when we do an update.

-scott
