From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 7/7] drivers: isdn: act2000: capi.c: add macro \ and fix
 brace
Date: Sat, 07 Feb 2015 22:12:09 +0300
Message-ID: <54D66389.4030402@cogentembedded.com>
References: <1423335929-24926-1-git-send-email-baspeters93@gmail.com> <1423335929-24926-8-git-send-email-baspeters93@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bas Peters <baspeters93@gmail.com>, isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423335929-24926-8-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/07/2015 10:05 PM, Bas Peters wrote:

> This patch adds the \ that was accidentally deleted in patch 2. It also adds a brace after the else statement, which is required due to the fact that the if statement has braces.

    This won't do, fix up the patch #2 please. And please wrap your change log 
at 80 columns or less. And you forgot to sign off anyway. :-)

[...]

WBR, Sergei
