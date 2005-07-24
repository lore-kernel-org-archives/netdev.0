From: Kumar Gala <kumar.gala@freescale.com>
Subject: Re: [PATCH RFC]: PHY Abstraction Layer III
Date: Sun, 24 Jul 2005 09:20:50 -0500
Message-ID: <2A1209AF-773C-4F35-8A85-887257A2EA64@freescale.com>
References: <20050723215913.GA777@electric-eye.fr.zoreil.com>
Mime-Version: 1.0 (Apple Message framework v733)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
In-Reply-To: <20050723215913.GA777@electric-eye.fr.zoreil.com>
To: Francois Romieu <romieu@fr.zoreil.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

Because the patch is all new code.  drivers/net/phy/phy.c doesn't  
exist in any kernel tree.  The patch is adding it.

- kumar

On Jul 23, 2005, at 4:59 PM, Francois Romieu wrote:

> Andy Fleming <afleming@freescale.com> :
>
>> Here's the latest version of the patch, done against a cogito
>> linux-2.6 branch.
>>
>
> The patch includes a diff against drivers/net/phy/phy.c which does not
> seem to exist in my -rc3-git4 local tree. Where can it be found ?
>
> --
> Ueimor
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
