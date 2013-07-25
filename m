From: Prashant Shah <pshah.mumbai@gmail.com>
Subject: Re: [PATCH] Change request_irq() to use struct net_device *dev->name
Date: Thu, 25 Jul 2013 10:49:25 +0530
Message-ID: <CAD6i1fJO3geZ0vkHLsJEd+KedHkpC1OZVTJJskU2RAAKYBhhJQ@mail.gmail.com>
References: <1374646199-9398-1-git-send-email-pshah.mumbai@gmail.com>
	<51F07489.7010404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-mentors@selenic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ryan Mallon <rmallon@gmail.com>
Return-path: <kernel-mentors-bounces@selenic.com>
In-Reply-To: <51F07489.7010404@gmail.com>
List-Unsubscribe: <http://selenic.com/mailman/options/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=unsubscribe>
List-Archive: <http://selenic.com/pipermail/kernel-mentors>
List-Post: <mailto:kernel-mentors@selenic.com>
List-Help: <mailto:kernel-mentors-request@selenic.com?subject=help>
List-Subscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=subscribe>
Sender: kernel-mentors-bounces@selenic.com
Errors-To: kernel-mentors-bounces@selenic.com
List-Id: netdev.vger.kernel.org

Hi,

> You should also remove the definition of DRV_NAME, since it is no longer
> used. The changelog should probably mention that this will change the
> interrupt name (which appears in /proc/interrupts for example) from "wd"
> to "eth%d".
>

I will resend the patch.

Regards.
