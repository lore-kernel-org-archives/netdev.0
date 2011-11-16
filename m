From: David Miller <davem@davemloft.net>
Subject: Re: [RFT] bridge: checksum not updated after pull
Date: Wed, 16 Nov 2011 17:47:30 -0500 (EST)
Message-ID: <20111116.174730.1997198538787965669.davem@davemloft.net>
References: <4EC23EE7.2010606@intel.com>
	<20111115100914.0c9540be@nehalam.linuxnetplumber.net>
	<CAM1AHpQsYz=y8m_RSzfPkGXGFZ8rQQE0Q+pmfbRb6K0v-jQ91w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: zheng.z.yan@intel.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, wcang@sfc.wide.ad.jp
To: martin.volf.42@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAM1AHpQsYz=y8m_RSzfPkGXGFZ8rQQE0Q+pmfbRb6K0v-jQ91w@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Martin Volf <martin.volf.42@gmail.com>
Date: Tue, 15 Nov 2011 20:51:44 +0100

> On 15 November 2011 19:09, Stephen Hemminger <shemminger@vyatta.com> wrote:
>> I think this is what is necessary, please test.
> ...
> 
> Hello,
> 
> with the patch on top of 3.1.1 I no longer get the "hw csum failure"
> message. I don't know how to test IPv6 multicast, but IPv6 ND and
> SLAAC is correctly passing through the bridge.

Applied, thanks Stephen.
