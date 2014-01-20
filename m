From: Branimir Maksimovic <branimir.maksimovic@gmail.com>
Subject: Re: Poor network performance x86_64.. also with 3.13
Date: Tue, 21 Jan 2014 00:27:59 +0100
Message-ID: <52DDB0FF.1050300@gmail.com>
References: <52DAD66F.7080306@dragonslave.de> <20140118195026.GA15543@pd.tnic> <52DB0439.2060905@dragonslave.de> <52DDA2CD.9040001@dragonslave.de> <20140120223752.GA3057@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Borislav Petkov <bp@alien8.de>, Daniel Exner <dex@dragonslave.de>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140120223752.GA3057@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/20/2014 11:37 PM, Borislav Petkov wrote:
> On Mon, Jan 20, 2014 at 11:27:25PM +0100, Daniel Exner wrote:
>> I just did the same procedure with Kernel Version 3.13: same poor rates.
>>
>> I think I will try to see of 3.12.6 was still ok and bisect from there.
> Or try something more coarse-grained like 3.11 first, then 3.12 and then
> the -rcs in between.
>
Hm, on my machine 3.13 (latest git) has double throughtput of 3.11 (distro
compiled) on loopback interface. 68Gb vs 33Gb (iperf).
