From: Andrej Gelenberg <andrej.gelenberg@udo.edu>
Subject: Re: iwlagn regression in v3.1.5
Date: Sun, 11 Dec 2011 17:58:58 +0100
Message-ID: <4EE4E152.2070204@udo.edu>
References: <4EE4AEF4.2080702@udo.edu> <4EE4DB55.4090804@udo.edu> <20111211174138.79e51fe8@x220.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Udo Steinberg <udo@hypervisor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111211174138.79e51fe8@x220.fritz.box>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this is pretty mean regression for the stable kernel. You may the fix 
only for cards, which need it and not for all of them.

Regards,
Andrej

On 12/11/2011 05:41 PM, Udo Steinberg wrote:
> Hi,
>
> The patch fixes the following bug:
> http://bugzilla.intellinuxwireless.org/show_bug.cgi?id=2326
>
> If the patch introduces a regression for you, then the problem needs to be
> investigated further. Reverting the patch will reintroduce an already fixed
> problem for others.
>
> Cheers,
>
> 	- Udo
>
