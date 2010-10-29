From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH iproute2] Support 'mode' parameter when creating macvtap device
Date: Fri, 29 Oct 2010 08:27:12 +0200
Message-ID: <201010290827.12198.arnd@arndb.de>
References: <1288307440.30131.81.camel@sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" l <kvm@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1288307440.30131.81.camel@sridhar.beaverton.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 29 October 2010, Sridhar Samudrala wrote:
> Add support for 'mode' parameter when creating a macvtap device.
> This allows a macvtap device to be created in bridge, private or
> the default vepa modes.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Acked-by: Arnd Bergmann <arnd@arndb.de>

