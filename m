From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v4 0/7] vmxnet3: upgrade to version 3
Date: Tue, 14 Jun 2016 13:22:02 -0700
Message-ID: <5760676A.7070103@gmail.com>
References: <1465930348-92164-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Shrikrishna Khare <skhare@vmware.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pv-drivers@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465930348-92164-1-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/14/2016 11:52 AM, Shrikrishna Khare wrote:
> This patchset upgrades vmxnet3 to version 3.
> 
> Changes in v2:
>  - Following patch is updated. See that patch for details:
>    vmxnet3: add support for get_coalesce, set_coalesce ethtool
> 
> Changes in v3:
>  - fix subject line to use vmxnet3: instead of Driver:Vmxnet3
>  - resubmit when net-next is open
> 
> Changes in v4:
>  - Following patch is updated. See that patch for details:
>    vmxnet3: add support for get_coalesce, set_coalesce ethtool

You really need to improve your commit messages, because right now they
are inexistent or too obvious to be of any value. A reviewer must be
introduced to what code changes he/she is going to review next by
looking at the diff and whether this will match or not the description
that was provided in the commit message.
-- 
Florian
