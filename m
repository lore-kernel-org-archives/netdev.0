From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv3 0/6] sh_eth: add wake-on-lan support via magic packet
Date: Tue, 10 Jan 2017 00:48:28 +0300
Message-ID: <a957f04f-0784-fa39-b7b0-8b8bd68c2a30@cogentembedded.com>
References: <20170109153409.13956-1-niklas.soderlund+renesas@ragnatech.se>
 <20170109.155542.1563572267512721426.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: horms+renesas@verge.net.au, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, geert@linux-m68k.org,
        linux-pm@vger.kernel.org
To: David Miller <davem@redhat.com>,
        niklas.soderlund+renesas@ragnatech.se
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170109.155542.1563572267512721426.davem@redhat.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/09/2017 11:55 PM, David Miller wrote:

>> This series adds support for Wake-on-Lan using Magic Packet for a few
>> models of the sh_eth driver. Patch 1/6 fix a naming error, patch 2/6
>> adds generic support to control and support WoL while patches 3/6 - 6/6
>> enable different models.
>>
>> Based ontop of net-next master.
>  ...
>
> Series applied, thanks.

    That was too quick for me... I hadn't even started looking into the main 
patch yet. :-/

MBR, Sergei
