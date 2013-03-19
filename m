From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Subject: Re: Re: [BUG][mvebu] mvneta: cannot request irq 25 on openblocks-ax3
Date: Tue, 19 Mar 2013 23:19:05 +0900
Message-ID: <514873D9.6060704@hitachi.com>
References: <51486445.8040506@hitachi.com> <20130319133324.GS13280@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"yrl.pp-manager.tt@hitachi.com" <yrl.pp-manager.tt@hitachi.com>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130319133324.GS13280@titan.lakedaemon.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jason,

(2013/03/19 22:33), Jason Cooper wrote:
> On Tue, Mar 19, 2013 at 10:12:37PM +0900, Masami Hiramatsu wrote:
>> Hi,
>>
>> Here I've hit a bug on the recent kernel. As far as I know, this bug
>> exists on 3.9-rc1 too.
>>
>> When I tried the latest mvebu for-next tree
>> (git://git.infradead.org/users/jcooper/linux.git mvebu/for-next),
> 
> FYI: that branch isn't stable, it's used as a merge-test of
> arm-soc/for-next (also not stable) and any branches I am trying to push
> upstream that day.

Thanks! could you tell me which branch is stable?
(however, I'd like to try new fixes/features on my device too :))

> Gregory has a patch in the works for this.  Hopefully he'll submit
> it by the end of the week.

Thank you,

-- 
Masami HIRAMATSU
IT Management Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com
