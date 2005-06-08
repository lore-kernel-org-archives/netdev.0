From: "David S. Miller" <davem@davemloft.net>
Subject: Re: ipw2100: firmware problem
Date: Wed, 08 Jun 2005 12:54:19 -0700 (PDT)
Message-ID: <20050608.125419.18305230.davem@davemloft.net>
References: <42A7268D.9020402@linux.intel.com>
	<20050608.124332.85408883.davem@davemloft.net>
	<20050608194902.GK876@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jketreno@linux.intel.com, vda@ilport.com.ua, pavel@ucw.cz,
        jgarzik@pobox.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        ipw2100-admin@linux.intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davej@redhat.com
In-Reply-To: <20050608194902.GK876@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@redhat.com>
Date: Wed, 8 Jun 2005 15:49:02 -0400

> FWIW, I agree, though the licensing of the Intel firmware
> prevents that iirc.  The biggest problem I face with this driver
> in Fedora kernels is users mismatching firmware rev with the
> driver version. Another problem that disappears if the two
> are shipped together.

Yep, this license definitely hurts users, in many many ways.

If this kind of external firmware requirement existed for a popular
SCSI controller, more people would be up in arms about this and
understand the issue more clearly.
