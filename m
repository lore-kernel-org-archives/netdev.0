From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [RFC PATCH net-next v4 1/2] macb: Add 1588 support in Cadence GEM.
Date: Tue, 3 Jan 2017 16:18:58 +0530
Message-ID: <CAFcVECLqnOx9cJay_2j1QPwUpE5PrLYf28Sh43D-Otz_Z35Q3w@mail.gmail.com>
References: <1481720175-12703-1-git-send-email-andrei.pistirica@microchip.com>
 <BN3PR07MB2516815EDE69ACDCE27F81A3C96F0@BN3PR07MB2516.namprd07.prod.outlook.com>
 <20170102113155.GA16373@localhost.localdomain>
 <0717c63b-2e29-9ad1-7f01-39817980933f@atmel.com>
 <20170102161359.GD3609@localhost.localdomain>
 <CAFcVECK1vt7Hu4tgSZ2+kKpMxoT-wpikMDq65HaxRv-EMgobHA@mail.gmail.com>
 <20170103102958.GC24780@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "tbultel@pixelsurmer.com" <tbultel@pixelsurmer.com>,
 Rafal Ozieblo <rafalo@cadence.com>,
 "boris.brezillon@free-electrons.com" <boris.brezillon@free-electrons.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "alexandre.belloni@free-electrons.com" <alexandre.belloni@free-electrons.com>,
 Nicolas Ferre <nicolas.ferre@atmel.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Andrei Pistirica <andrei.pistirica@microchip.com>,
 "michals@xilinx.com" <michals@xilinx.com>,
 "anirudh@xilinx.com" <anirudh@xilinx.com>,
 "punnaia@xilinx.com" <punnaia@xilinx.com>,
 "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170103102958.GC24780@localhost.localdomain>
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

Hi Richard,

On Tue, Jan 3, 2017 at 3:59 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Tue, Jan 03, 2017 at 10:36:11AM +0530, Harini Katakam wrote:
>> I understand that it is not accurate - it is an initial version.
>
> Why do you say, "it is an initial version?"
>
> The Atmel device has this IP core burned in.  The core is hopelessly
> broken, and it cannot be fixed in SW either, so what is your point?
>

I'm sorry - I just meant that this was before many necessary
enhancements and fixes.
Newer SoCs including ZynqMP (for which the original series was sent)
have the descriptor based approach which is reliable.

Regards,
Harini
