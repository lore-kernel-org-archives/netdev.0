From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] packet delay scheduler
Date: 22 Mar 2004 08:40:07 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1079962807.1039.1259.camel@jzny.localdomain>
References: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
	 <20040316174134.2f1da12a.davem@redhat.com>
	 <20040318120451.1c9ee286@dell_ss3.pdx.osdl.net>
	 <1079707927.1032.42.camel@jzny.localdomain>
	 <20040319142112.0ad562fe.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040319142112.0ad562fe.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-03-19 at 17:21, David S. Miller wrote:

> But for now we can put Stephen's delay scheduler in the tree, and I
> don't see any real problem with that until your tc action changes
> are ready for integration.

Absolutely - sorry intent was just to motivate not reject.

I would say the extension patches are ready for inclusion but we can
take that offline. I have a few people testing them under more rigorous
conditions at the moment.

cheers,
jamal
