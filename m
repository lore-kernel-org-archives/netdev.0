From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5] sis900 debugging and revision code
Date: Thu, 06 Jan 2005 18:35:48 -0500
Message-ID: <41DDCB54.2080101@pobox.com>
References: <20041212121852.GA16325@gateway.milesteg.arr> <20041212123031.GB16325@gateway.milesteg.arr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniele Venzano <webvenza@libero.it>
In-Reply-To: <20041212123031.GB16325@gateway.milesteg.arr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patches 1, 2, and 5 are OK.

For the other two patches, I don't want to deviate from the style that 
has been standard for years:  dev->name prefix, followed by message.

It may make greps easier for you, but it becomes a non-standard style 
and may make existing sysadmin scripts out in the field.

Please resend series without the PFX-where-devname-is-known changes.

	Jeff
