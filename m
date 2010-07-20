From: Alex Badea <abadea@ixiacom.com>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network interfaces
 with random MAC address
Date: Tue, 20 Jul 2010 14:58:08 +0300
Message-ID: <4C458F50.4070200@ixiacom.com>
References: <4C457F72.8090708@redhat.com> <1279624844.2110.3.camel@achroite.uk.solarflarecom.com> <4C458CB7.3030508@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, Andy Gospodarek <gospo@redhat.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Casey Leedom <leedom@chelsio.com>,
	Harald Hoyer <harald@redhat.com>
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C458CB7.3030508@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 07/20/2010 02:47 PM, Stefan Assmann wrote:
>> What about devices that 'steal' MAC addresses from slave devices?

Might I suggest an attribute such as "address_type", which could report
"permanent", "random", "stolen", or something else in the future?

My two cents,
Alex
