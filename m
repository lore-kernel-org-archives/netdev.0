From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 10071] New: kernel hang in inet_init
Date: Wed, 27 Feb 2008 13:49:48 +0000
Message-ID: <20080227134948.GA6422@ff.dom.local>
References: <20080225140034.5ef88935.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-acpi@vger.kernel.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>
To: yannick.dirou@axetic.com
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080225140034.5ef88935.akpm@linux-foundation.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25-02-2008 23:00, Andrew Morton wrote:
> On Sat, 23 Feb 2008 00:34:06 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=10071
...
>>      KernelVersion: 2.6.25 rc2 latest git
...
>> there seem to be a weird interaction between acpi and inet_init
>>
>> any hint on how to provide better information

Yannick, here are a few questions:

- is this bug just with this git, but OK before (or 2.6.25-rc3?)?
- do all other drivers work properly and only net is a problem?
- could you add to bugzilla full dmesg in both cases?

Regards,
Jarek P.
