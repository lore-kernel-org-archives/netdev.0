From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [sparse] get rid of warnings from 8139too driver
Date: Wed, 30 Jun 2004 16:40:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40E32535.30807@pobox.com>
References: <20040622135122.05be2be1@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040622135122.05be2be1@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Get rid of sparse warnings from 8139too driver. 
> 	* move start_thread which was inline into the open routine (only place called).

as mentioned by Francois, I prefer the code separate, for clarity.

	Jeff
