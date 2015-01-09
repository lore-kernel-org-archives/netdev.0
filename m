From: Ian Campbell <ijc@hellion.org.uk>
Subject: Re: [PATCH v2 1/3] dtb: xgene: fix: Backward compatibility with
 older firmware
Date: Fri, 09 Jan 2015 17:36:48 +0000
Message-ID: <1420825008.21186.50.camel@hellion.org.uk>
References: <1415044796-5081-1-git-send-email-isubramanian@apm.com>
 <1415044796-5081-2-git-send-email-isubramanian@apm.com>
 <1420819166.21186.38.camel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org, patches@apm.com,
 kchudgar@apm.com, davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1420819166.21186.38.camel@citrix.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-01-09 at 15:59 +0000, Ian Campbell wrote:
> I'm running mustang_sw_1.13.29-beta, using the mustang_tianocore_ubt.fd
> method to launch from u-boot.

I realised shortly after that I had downloaded 1.14.14 too, but it
behaves the same.

I rebuilt mustang_tianocore_ubt.fd with the first hunk of this patch and
things now work.

Ian.
