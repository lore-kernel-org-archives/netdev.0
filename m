From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ixgb fixes
Date: Thu, 26 Feb 2004 00:54:47 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <403D8A27.20703@pobox.com>
References: <20040115140248.170a3ee3.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <Ganesh.Venkatesan@intel.com>,
        "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <20040115140248.170a3ee3.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Ixgb driver in 2.6.1 (possibly 2.4) has several problems:
> 	* register_netdev error never handled
> 	* returns -ENOMEM for errors like bad eeprom etc
> 	* keeps copy of device name in the private data structure
> 	  which is never used, and would be wrong anyway if
> 	  the device was renamed.


Hey Intel guys...  is this driver alive or dead?

	Jeff
