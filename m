From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: e100-3.0.0_dev8 "Minneapolis Moline" release
Date: Wed, 18 Jun 2003 09:39:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010107D979@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jason Lunz" <lunz@falooley.org>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Is the anonymous union in struct cb some kind of gcc3-only 
> thing? It doesn't compile for my debian woody gcc 2.95 unless 
> I name the union member.

I'm not sure, but it's easy enough to make it known to avoid the issue.
I'll do that.

-scott
