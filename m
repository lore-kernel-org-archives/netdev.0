From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 7/9] selftests: Update ptp Makefile to work under
 selftests
Date: Sat, 10 Sep 2016 16:32:15 +0300
Message-ID: <489dc10b-73f1-2743-5980-b493146fe696@cogentembedded.com>
References: <cover.1473458697.git.shuahkh@osg.samsung.com>
 <cade45ccc160f91658980cda42ef5b5322182d68.1473458697.git.shuahkh@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-kselftest@vger.kernel.org
To: Shuah Khan <shuahkh@osg.samsung.com>, corbet@lwn.net,
        richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cade45ccc160f91658980cda42ef5b5322182d68.1473458697.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 9/10/2016 1:22 AM, Shuah Khan wrote:

> Update ptp Makefile to work under selftests. ptp will not be run as part
> of selftests suite and will not included in install targets. They can be
                                  ^ be

> built separately for now.
>
> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
[...]

MBR, Sergei
