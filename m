From: Shuah Khan <shuah@kernel.org>
Subject: Re: [PATCH][net-next][V3] bpf: test_maps: fix typos, "conenct" and
 "listeen"
Date: Wed, 30 Aug 2017 14:13:35 -0600
Message-ID: <9863bea1-5325-edc8-ca46-46e2a738782c@kernel.org>
References: <20170830171525.5688-1-colin.king@canonical.com>
 <59A70831.6080501@iogearbox.net>
Reply-To: shuah@kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Shuah Khan <shuah@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Colin King <colin.king@canonical.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shuah Khan <shuahkh@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <59A70831.6080501@iogearbox.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/30/2017 12:47 PM, Daniel Borkmann wrote:
> On 08/30/2017 07:15 PM, Colin King wrote:
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> Trivial fix to typos in printf error messages:
>> "conenct" -> "connect"
>> "listeen" -> "listen"
>>
>> thanks to Daniel Borkmann for spotting one of these mistakes
>>
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> 
> 

I can get this into 4.14-rc1 unless it should go through net-next
for dependencies. In which case,

Acked-by: Shuah Khan <shuahkh@osg.samsung.com>

thanks,
-- Shuah
