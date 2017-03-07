From: Geoff Levand <geoff@infradead.org>
Subject: Re: [PATCH] net: toshiba: ps3_genic_net: use new api
 ethtool_{get|set}_link_ksettings
Date: Tue, 7 Mar 2017 11:40:17 -0800
Message-ID: <59884351-386f-f904-790b-186fc1bf58e2@infradead.org>
References: <1488752466-27232-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, benh@kernel.crashing.org,
 paulus@samba.org, mpe@ellerman.id.au, davem@davemloft.net
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1488752466-27232-1-git-send-email-tremyfr@gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

On 03/05/2017 02:21 PM, Philippe Reynes wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
>
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.

I tested this applied to v4.11-rc1 and it seems to work OK.
Thanks for your contribution.

Tested-by: Geoff Levand <geoff@infradead.org>
