From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH 1/7] Introduce FUJITSU Extended Socket Network Device
 driver
Date: Wed, 20 May 2015 09:58:18 -0700
Message-ID: <555CBD2A.9030001@redhat.com>
References: <E86EADE93E2D054CBCD4E708C38D364A5422D82D@G01JPEXMBYT01>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: "Hart, Darren" <darren.hart@intel.com>,
	"rkhan@redhat.com" <rkhan@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>
To: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>,
	"platform-driver-x86@vger.kernel.org"
	<platform-driver-x86@vger.kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <E86EADE93E2D054CBCD4E708C38D364A5422D82D@G01JPEXMBYT01>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/20/2015 01:17 AM, Izumi, Taku wrote:
> 
> This patch adds the skelton code of FUJITSU Extended Socket
> Network Device driver.
> At this stage, this driver just outputs its driver name at
> loading time.
> 
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>

This patch and the second one can probably be combined.  There isn't
much point in splitting the two up since this one doesn't really do
anything without at least the second one.

- Alex
