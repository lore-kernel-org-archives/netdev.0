From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: jme driver loses connection after resuming from suspend
Date: Fri, 28 Jan 2011 16:33:15 -0800
Message-ID: <20110128163315.1e4e8346.akpm@linux-foundation.org>
References: <AANLkTikrKEY7Zt5HvxQcJLk9eGne0BGD82NFEiWO4smt@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Guo-Fu Tseng <cooldavid@cooldavid.org>, netdev@vger.kernel.org
To: "Leonardo  L. P. da Mata" <barroca@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikrKEY7Zt5HvxQcJLk9eGne0BGD82NFEiWO4smt@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(cc's added)

On Fri, 28 Jan 2011 16:03:11 -0200
"Leonardo  L. P. da Mata" <barroca@gmail.com> wrote:

> Hello, i'm testing the kernel 2.6.37 on my hardware, Once connect on
> wired network, i call the suspend with:
> echo "mem" >/sys/power/state
> 
> The system goes on suspend. After resuming from suspend, the network card
> cannot be used anymore.
> 
> 
> The bug is reported here:
>  https://bugzilla.kernel.org/show_bug.cgi?id=27692
> 
> Can you please point me to similar problems on other network cards so
> i can get possible solutions on this.
