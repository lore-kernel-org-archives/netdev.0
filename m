From: Michael Iatrou <m.iatrou@freemail.gr>
Subject: Re: IPsec performance over UDP
Date: Tue, 10 May 2005 23:35:19 +0300
Message-ID: <200505102335.20023.m.iatrou@freemail.gr>
References: <200505101949.12236.m.iatrou@freemail.gr> <42810057.4020800@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-7"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <42810057.4020800@hp.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When the date was Tuesday 10 May 2005 21:41, Rick Jones wrote:

> > The "unexpected" result is that there is 30% idle time even if the
> > network is not saturated!
>
> Perhaps the sending side got intra-stack flow-controlled?

In that case, plain IP should't also have the same problem (it hasn't)?

-- 
 Michael Iatrou
 Electrical and Computer Engineering Dept.
 University of Patras, Greece
