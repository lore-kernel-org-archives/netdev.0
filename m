From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC/PATCH] network configs: disconnect network options from
	drivers
Date: 31 Mar 2005 06:04:48 -0500
Message-ID: <1112267088.1089.53.camel@jzny.localdomain>
References: <20050330234709.1868eee5.randy.dunlap@verizon.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ioe-lkml@axxeo.de, matthew@wil.cx,
	lkml <linux-kernel@vger.kernel.org>, netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261307AbVCaLE5@vger.kernel.org>
To: "Randy.Dunlap" <randy.dunlap@verizon.net>
In-Reply-To: <20050330234709.1868eee5.randy.dunlap@verizon.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-31 at 02:47, Randy.Dunlap wrote:
> RFC:  This is a work-in-progress (WIP), not yet completed.
> 
> A few people dislike that the Networking Options menu is inside
> the Device Drivers/Networking menu.  This patch moves the
> Networking Options menu to immediately before the Device Drivers menu,
> renames it to "Networking options and protocols", & moves most
> protocols to more logical places (IMHOOC).
> 

About time someone brave did this.

cheers,
jamal
