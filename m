From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] net: replace random_ether_addr() with
	eth_hw_addr_random()
Date: Wed, 15 Feb 2012 15:34:45 -0500 (EST)
Message-ID: <20120215.153445.1279062916210043775.davem@davemloft.net>
References: <1329324340-13461-1-git-send-email-danny.kukawka@bisect.de>
	<1329324340-13461-2-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, venza@brownhat.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	dkukawka@suse.de, linux-kernel@vger.kernel.org,
	nicolas.ferre@atmel.com, rl@hellgate.ch,
	hsweeten@visionengravers.com, gregkh@linuxfoundation.org,
	peppe.cavallaro@st.com, steve.glendinning@smsc.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	virtualization@lists.linux-foundation.org, florian@openwrt.org,
	khc@pm.waw.pl
To: danny.kukawka@bisect.de
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1329324340-13461-2-git-send-email-danny.kukawka@bisect.de>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Wed, 15 Feb 2012 17:45:39 +0100

> Replace usage of random_ether_addr() with eth_hw_addr_random()
> to set addr_assign_type correctly to NET_ADDR_RANDOM.
> 
> Change the trivial cases.
> 
> v2: adapt to renamed eth_hw_addr_random()
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Applied.
