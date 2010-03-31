From: Bryan Wu <bryan.wu@canonical.com>
Subject: Re: [PATCH] netdev/fec.c: add phylib supporting to enable carrier
	detection
Date: Wed, 31 Mar 2010 11:07:41 +0800
Message-ID: <4BB2BC7D.7090904@canonical.com>
References: <1269597052-10104-1-git-send-email-bryan.wu@canonical.com>
	<20100327125703.GB5880@pengutronix.de>
	<4BB06769.7040708@canonical.com>
	<20100331030602.GD3520@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de,
	linux-kernel@vger.kernel.org, kernel-team@lists.ubuntu.com,
	gerg@uclinux.org, linux-arm-kernel@lists.infradead.org
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <kernel-team-bounces@lists.ubuntu.com>
In-Reply-To: <20100331030602.GD3520@pengutronix.de>
List-Unsubscribe: <https://lists.ubuntu.com/mailman/listinfo/kernel-team>,
	<mailto:kernel-team-request@lists.ubuntu.com?subject=unsubscribe>
List-Archive: <https://lists.ubuntu.com/archives/kernel-team>
List-Post: <mailto:kernel-team@lists.ubuntu.com>
List-Help: <mailto:kernel-team-request@lists.ubuntu.com?subject=help>
List-Subscribe: <https://lists.ubuntu.com/mailman/listinfo/kernel-team>,
	<mailto:kernel-team-request@lists.ubuntu.com?subject=subscribe>
Sender: kernel-team-bounces@lists.ubuntu.com
Errors-To: kernel-team-bounces@lists.ubuntu.com
List-Id: netdev.vger.kernel.org

Wolfram Sang wrote:
> On Mon, Mar 29, 2010 at 04:40:09PM +0800, Bryan Wu wrote:
>   
>> On 03/27/2010 08:57 PM, Wolfram Sang wrote:
>>     
>>> On Fri, Mar 26, 2010 at 05:50:52PM +0800, Bryan Wu wrote:
>>>       
>>>> BugLink: http://bugs.launchpad.net/bugs/457878
>>>>
>>>>   - removed old MII phy control code
>>>>   - add phylib supporting
>>>>   - add ethtool interface to make user space NetworkManager works
>>>>
>>>> Tested on Freescale i.MX51 Babbage board.
>>>>         
>>> Sadly, I have problems here booting a custom board:
>>>
>>>       
>> Firstly, I working on our Ubuntu Lucid 2.6.31 based kernel. This patch works
>> fine on our system. Then I forward port it to 2.6.34-rc2 Linus mainline kernel.
>> It also works fine on my hardware.
>>     
>
> Hmm, can I provide some more information to get an idea what is happening here?
>
>   
No problem, man. I do love to help this.

-Bryan
