From: Andy Whitcroft <apw@canonical.com>
Subject: Re: kerneloops.org report for the week of October 31 2009
Date: Mon, 2 Nov 2009 08:31:12 +0000
Message-ID: <25d66d860911020031p6f7772d2w3aca808d25c6d7@mail.gmail.com>
References: <20091031160351.26fcc6c5@infradead.org>
	 <200911010020.20284.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	linux-acpi@vger.kernel.org, tytso@mit.edu, netdev@vger.kernel.org,
	Eric Paris <eparis@redhat.com>, akpm@linux-foundation.org,
	Matt Domsch <Matt_Domsch@dell.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <200911010020.20284.rjw@sisk.pl>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This should be fixed by commit 04bf7539c08d64184736cdc5e4ad617eda77eb0f
> (PM: Make warning in suspend_test_finish() less likely to happen), at least on some
> machines that report it.

That commit has been pulled back to the first 9.10 updates kernel to
reduce the noise.

-apw
