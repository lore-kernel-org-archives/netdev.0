From: Zwane Mwaikambo <zwane@linuxpower.ca>
Subject: RE: e1000 lockup with port io type reset
Date: Sat, 28 Jun 2003 01:47:21 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0306280145260.16505@montezuma.mastecende.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107DA2C@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010107DA2C@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 27 Jun 2003, Feldman, Scott wrote:

> > The following card causes a hard lockup when we do a controller 
> > reset using port io instead of mmio. Switching to mmio 
> > controller reset causes it to function as expected
> 
> Please send me a description of system (model, kernel, DMI decode, etc),
> plus dumps from lspci -vv -xxx and ethtool -d ethX.  If we can repro
> this, we should be able to get a bus trace.

Thanks, i just have to wait on the dmi decode. I'll have it to you ASAP.

	Zwane
-- 
function.linuxpower.ca
