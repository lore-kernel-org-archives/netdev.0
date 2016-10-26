From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH v2 1/5] kconfig: introduce the "imply" keyword
Date: Thu, 27 Oct 2016 01:28:47 +0200
Message-ID: <1477524527.2121.15.camel@tiscali.nl>
References: <1477448931-29051-1-git-send-email-nicolas.pitre@linaro.org>
         <1477448931-29051-2-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Michal Marek <mmarek@suse.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477448931-29051-2-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-10-25 at 22:28 -0400, Nicolas Pitre wrote:
> SUBSYSTEM_X can still be configured out, and it can be set as a 
> module when none of the drivers are selected or all of them are also 
> modular.

Short note, to highlight a pet peeve: "select" (and therefor
"selected") has a special meaning in kconfig land. I guess you meant
something neutral like "set" here. Is that correct?

By the way: "also" makes this sentence hard to parse.


Paul Bolle
