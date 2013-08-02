From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 0/3] networking: Use ETH_ALEN where appropriate
Date: Fri, 02 Aug 2013 12:34:42 -0700 (PDT)
Message-ID: <20130802.123442.500196593983076682.davem@davemloft.net>
References: <20130801.143137.331385226409040561.davem@davemloft.net>
	<cover.1375398692.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netfilter-devel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
To: joe@perches.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <cover.1375398692.git.joe@perches.com>
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

From: Joe Perches <joe@perches.com>
Date: Thu,  1 Aug 2013 16:17:46 -0700

> Convert the uses mac addresses to ETH_ALEN so
> it's easier to find and verify where mac addresses
> need to be __aligned(2)

Series applied to net-next, thanks.
