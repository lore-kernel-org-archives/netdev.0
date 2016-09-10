From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 9/9] selftests: Update vDSO Makefile to work under
 selftests
Date: Sat, 10 Sep 2016 16:33:24 +0300
Message-ID: <819386de-26ec-cb69-eb8e-94dcb283711f@cogentembedded.com>
References: <cover.1473458697.git.shuahkh@osg.samsung.com>
 <2034b315d4f40df479ba7ada1580a22fd91a75b4.1473458697.git.shuahkh@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-kselftest@vger.kernel.org
To: Shuah Khan <shuahkh@osg.samsung.com>, corbet@lwn.net,
        richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2034b315d4f40df479ba7ada1580a22fd91a75b4.1473458697.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/10/2016 1:22 AM, Shuah Khan wrote:

> Update vDSO Makefile to work under selftests. vDSO will not be run as part
> of selftests suite and will not included in install targets. They can be
                                  ^ be

> built separately for now.
>
> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
[...]

MBR, Sergei
