From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] (1/12) skge: use PFX string
Date: Thu, 03 Mar 2005 16:37:34 -0500
Message-ID: <4227839E.7010208@pobox.com>
References: <20050303114557.6373662b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050303114557.6373662b@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Applied patches 1-12, but comments follow.

Also, a procedural comment:

Please place the "1/12" number _inside_ square brackets, like so:

	[PATCH 1/12] skge: use PFX string

Reason:  Everything inside the brackets is converted to the constant 
string "[PATCH]".  With your submission, I had to hand-edit 12 comments, 
removing the "x/12" from each one.

	Jeff
