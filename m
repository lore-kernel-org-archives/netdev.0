From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH v2 2/5] kconfig: introduce the "suggest" keyword
Date: Thu, 27 Oct 2016 02:10:45 +0200
Message-ID: <1477527045.2121.26.camel@tiscali.nl>
References: <1477448931-29051-1-git-send-email-nicolas.pitre@linaro.org>
         <1477448931-29051-3-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>,
        John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Michal Marek <mmarek@suse.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1477448931-29051-3-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-10-25 at 22:28 -0400, Nicolas Pitre wrote:
> Similar to "imply" but with no added restrictions on the target symbol's
> value. Useful for providing a default value to another symbol.
> 
> Suggested by Edward Cree.
> 
> Signed-off-by: Nicolas Pitre <nico@linaro.org>

As far as I can see this series doesn't add a user of "suggest". So I
see no reason to add it.

NAK.


Paul Bolle
