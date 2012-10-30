From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH] net: dsa/slave: Fix compilation warnings
Date: Tue, 30 Oct 2012 13:25:07 +0530
Message-ID: <CAKohpokmfFSFsADmtOyN9JRCX8aVdNs+tDFhUQuM6sSQ+dFfUA@mail.gmail.com>
References: <5afab1ebe83e4361f1fd75bbea0c559af195bf02.1351529738.git.viresh.kumar@linaro.org>
	<1351540778.2721.7.camel@bwh-desktop.uk.solarflarecom.com>
	<CAKohponL_3m2KVytiWm8ZHyB5aimk8CzGrqr5J0LMy8MFGodHg@mail.gmail.com>
	<CAKohponOKk5e2Sxyhjw-XvzVxF3tNp66rsnYCwvwHazAPAauKw@mail.gmail.com>
	<508F8779.8070300@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	linaro-dev@lists.linaro.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, patches@linaro.org
To: Daniel Lezcano <daniel.lezcano@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <508F8779.8070300@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30 October 2012 13:23, Daniel Lezcano <daniel.lezcano@linaro.org> wrote:
>> From: Viresh Kumar <viresh.kumar@linaro.org>

>>  config NET_DSA_TAG_DSA
>> -     bool
>> +     bool "Original DSA packet tagging format"
>> +     select NET_DSt
>
> typo NET_DSA

Unbelievable mistake :(

Will fix it after some reviews now :)

--
viresh
