From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-2.6] tehuti: Firmware filename is tehuti/bdx.bin
Date: Fri, 17 Dec 2010 10:34:35 -0500
Message-ID: <20101217153435.GA11221@gospo.rdu.redhat.com>
References: <1292595184.3136.843.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Joe Jin <joe.jin@oracle.com>,
	Alexander Indenbaum <baum@tehutinetworks.net>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Guru Anbalagane <guru.anbalagane@oracle.com>,
	"greg.marsden@oracle.com" <greg.marsden@oracle.com>,
	DuanZhenzhong <zhenzhong.duan@oracle.com>,
	Jaswinder Singh Rajput <jaswinder@infradead.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1292595184.3136.843.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 17, 2010 at 02:13:03PM +0000, Ben Hutchings wrote:
> My conversion of tehuti to use request_firmware() was confused about
> the filename of the firmware blob.  Change the driver to match the
> blob.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Thanks for doing that, Ben.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
