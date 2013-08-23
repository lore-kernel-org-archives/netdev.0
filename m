From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v6 0/5] cpsw: support for control module register
Date: Sat, 24 Aug 2013 01:08:56 +0530
Message-ID: <5217BA50.6050609@ti.com>
References: <1377286330-29663-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
 d-gerlach@ti.com, netdev@vger.kernel.org, nsekhar@ti.com, vaibhav.bedia@ti.com,
 bcousson@baylibre.com, ujhelyi.m@gmail.com, linux-omap@vger.kernel.org,
 davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1377286330-29663-1-git-send-email-zonque@gmail.com>
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

On Saturday 24 August 2013 01:02 AM, Daniel Mack wrote:
> Hi,
>
> this is the 6th version of my patch set, the version history is below.
>
> Note that for personal reasons, I won't be able to work on that patch
> set for two weeks, starting from a few hours from now. If there are any
> more objections or comments, I'll catch up after that period. Or if
> anyone wants to make minor changes to my patches and resubmit them,
> I'd also be fine with that :)
>
> The compatibility discussion is still ongoing, but I'd rather submit
> what I got until now, and I'm also still convinced that having
> ti,am3352-cpsw is the best we can do.
>
>
> Thanks,
> Daniel
>
> v5 -> v6:
> 	* re-add code to fail if 3rd memory region is given but invalid
> 	* added Mugunthan's ack on all patches except the one that adds
> 	  ti,am3352-cpsw
> 	* remove parens around integer constants
I am also in your favour of adding ti,am3352-cpsw, but lets get other
comment. You can add my ack to that patch also if you are submitting
another version.

Regards
Mugunthan V N
