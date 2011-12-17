From: David Miller <davem@davemloft.net>
Subject: Re: [patch] wimax/i2400m: remove an unused variable
Date: Fri, 16 Dec 2011 19:07:09 -0500 (EST)
Message-ID: <20111216.190709.1669440818860495373.davem@davemloft.net>
References: <20111216102242.GC4287@elgon.mountain>
	<3A78FAA0EC814D4B8ECC99B3AB32B332012E56@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	wimax@linuxwimax.org, dan.carpenter@oracle.com, linux-wimax@intel.com
To: inaky.perez-gonzalez@intel.com
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <3A78FAA0EC814D4B8ECC99B3AB32B332012E56@ORSMSX105.amr.corp.intel.com>
List-Unsubscribe: <http://lists.linuxwimax.org/options/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.linuxwimax.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://lists.linuxwimax.org/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Date: Fri, 16 Dec 2011 22:09:29 +0000

>> Subject: [patch] wimax/i2400m: remove an unused variable
>> 
>> "result" isn't used.  We ignore errors here because there is not much
>> we can do about them.
>> 
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> This is an ACK or a NAK depending on if you want to keep the reporting
> with debug enabled or not. It is not so difficult to add back if needed, 
> so I tend to ACK.

And FWIW I applied this to net-next already.
