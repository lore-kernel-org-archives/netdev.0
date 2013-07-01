From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] xen: Use more current logging styles
Date: Mon, 01 Jul 2013 13:31:53 -0700 (PDT)
Message-ID: <20130701.133153.968451539148790258.davem@davemloft.net>
References: <1372395469.2060.36.camel@joe-AO722>
	<1372406390.8976.67.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jeremy@goop.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, joe@perches.com
To: Ian.Campbell@citrix.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1372406390.8976.67.camel@zakaz.uk.xensource.com>
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

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Fri, 28 Jun 2013 08:59:50 +0100

> On Thu, 2013-06-27 at 21:57 -0700, Joe Perches wrote:
>> Instead of mixing printk and pr_<level> forms,
>> just use pr_<level>
>> 
>> Miscellaneous changes around these conversions:
>> 
>> Add a missing newline to avoid message interleaving,
>> coalesce formats, reflow modified lines to 80 columns.
>> 
>> Signed-off-by: Joe Perches <joe@perches.com>
> 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied.
