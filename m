From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] convert skge to pci_driver API (2nd try)
Date: Wed, 11 Aug 2004 15:35:48 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411A7514.30908@pobox.com>
References: <20040620112859.GA13794@lst.de> <4100F51C.3030709@syskonnect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@lst.de>, netdev@oss.sgi.com,
        Ralph Roesler <rroesler@syskonnect.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mirko Lindner <mlindner@syskonnect.de>
In-Reply-To: <4100F51C.3030709@syskonnect.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mirko Lindner wrote:
> Therefore we would like to keep our driver consistent and it's not 
> possible for us to merge your changes into our code tree. Please don't 


Unfortunately it is a requirement of Linux development that you track 
the upstream tree.

In particular, you "fell off the map" for months without a driver update 
or email, so it seems perfectly reasonable that other patches would get 
applied in the meantime.

	Jeff
