From: Mirko Lindner <demon@pro-linux.de>
Subject: Re: [PATCH] (1/23) sk98: no explicit module ref counting needed
Date: Fri, 12 Nov 2004 01:51:25 +0100
Message-ID: <4194090D.6000303@pro-linux.de>
References: <4192C60A.1050205@designassembly.de>	<20041111154016.6381189d@zqx3.pdx.osdl.net> <20041111161137.576e5f66@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Michael Heyse <mhk@designassembly.de>,
        Mirko Lindner <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041111161137.576e5f66@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks Stephen. We'll check the functionality and let you know as soon 
as possible.

Mirko

Stephen Hemminger wrote:
 > Network driver's shouldn't be doing module reference counting
 > on 2.6.  This is a bad replication of 2.4 behaviour
