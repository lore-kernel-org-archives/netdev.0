From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH net-next-2.6 v3] can: Topcliff: PCH_CAN driver: Add Flow
 control,
Date: Tue, 16 Nov 2010 12:04:43 +0100
Message-ID: <4CE2654B.20004@grandegger.com>
References: <4CE2434B.5050701@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@gmail.com>,
	Samuel Ortiz <sameo@linux.intel.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, andrew.chih.howe.khor@intel.com,
	qi.wang@intel.com, margie.foster@intel.com, yong.y.wang@intel.com,
	Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	kok.howg.ewe@intel.com, joel.clark@intel.com
To: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CE2434B.5050701@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tomoya,

On 11/16/2010 09:39 AM, Tomoya MORINAGA wrote:
> Hi Marc and Wolf,
> 
> I have updated your indications.
> 
>> * Add Flow control
>> * Fix Data copy issue (endianness)
>> * Add Macro prefix "PCH_"
>> * Separate interface register structure
>> * Some functions are unified.
>> * Change MessageObject indication(PCH_RX_OBJ_START, etc..)
>> * Enumerate LEC macro
>> * Move MSI processing from open/close to probe/remove processing
>> * Use BIT(x)
>> * and more...
> 
> Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>

Could you please resend the patch (as v4) with a proper subject and
commit message. Then I will add my "Acked-by" to get that
*not-yet-ready* driver updated quickly.

Wolfgang.
