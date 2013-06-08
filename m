From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/9] sh_eth: make driver build on any platform
Date: Sat, 08 Jun 2013 04:10:05 +0400
Message-ID: <51B2765D.7030604@cogentembedded.com>
References: <201306080351.39018.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, Paul Mundt <lethal@linux-sh.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306080351.39018.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/08/2013 03:51 AM, Sergei Shtylyov wrote:

>     This series of 9 patches are against Dave's 'net-next.git' repository.
>     The series deals with the #ifdef'fery around SoC support code/data in the
> 'sh_eth' driver. It doesn't yet get rid of all the #ifdef's: 3 are left, 1 of
> them still hinders ARM multiplatform build -- I'll try to deal with it next
> week.
>
> [1/9] sh_eth: create initial ID table
> [2/9] sh_eth: get SH771x support out of #ifdef
> [3/9] sh_eth: get SH7619 support out of #ifdef
> [4/9] sh_eth: get R8A7740 support out of #ifdef
> [5/9] sh_eth: get SH77{34|63} support out of #ifdef
> [6/9] sh_eth: get SH7757 support out of #ifdef
> [7/9] sh_eth: get SH7724 support out of #ifdef
> [8/9] sh_eth: get R8A777x support out of #ifdef
> [9/9] sh_eth: remove dependencies from Kconfig
>

    Sorry, Paul, forgot to include you into the CC list on most of the 
patches
and the cover letter. Please look for the patches on linux-sh and ACK them
if you deem necessary.

WBR, Serge

