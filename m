From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,v3] hyperv: Add support for virtual Receive
 Side Scaling (vRSS)
Date: Wed, 19 Mar 2014 23:41:46 -0400 (EDT)
Message-ID: <20140319.234146.1635130348995174527.davem@davemloft.net>
References: <1395180922-2776-1-git-send-email-haiyangz@microsoft.com>
 <20140319.164005.1815461875771862691.davem@davemloft.net>
 <532A1275.2020208@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
 haiyangz@microsoft.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <532A1275.2020208@cogentembedded.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 20 Mar 2014 00:56:05 +0300

> Hello.
> 
> On 03/19/2014 11:40 PM, David Miller wrote:
> 
>>> +extern u8 netvsc_hash_key[];
> 
>> We no longer use extern in header file function declarations.
> 
>    Wait, this is a variable declaration. :-)

My bad :)
