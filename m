From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v9 7/8] thunderbolt: Networking doc
Date: Thu, 10 Nov 2016 07:24:22 -0700
Message-ID: <20161110072422.484c89ad@lwn.net>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
        <1478701208-4585-8-git-send-email-amir.jer.levy@intel.com>
        <20161109160002.GA9111@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: Amir Levy <amir.jer.levy@intel.com>, andreas.noever@gmail.com,
        bhelgaas@google.com, linux-kernel@vger.kernel.org,
        linux-pci@vger.kernel.org, netdev@vger.kernel.org,
        linux-doc@vger.kernel.org, mario_limonciello@dell.com,
        thunderbolt-linux@intel.com, mika.westerberg@intel.com,
        tomas.winkler@intel.com, xiong.y.zhang@intel.com
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161109160002.GA9111@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Nov 2016 17:00:02 +0100
Greg KH <gregkh@linuxfoundation.org> wrote:

> >  Documentation/00-INDEX                   |   2 +
> >  Documentation/thunderbolt/networking.txt | 132 +++++++++++++++++++++++++++++++  
> 
> Note, new files should be in .rst format, and live in the new
> subdirectory for them (somewhere in Documentation, don't know off the
> top of my head...)

This one's almost in RST already, happily.

We haven't really figured out a hierarchy for device-specific docs like
this yet; I should get on that, I guess.

I do believe that we should separate documents for end users from those
aimed at kernel developers; those are two very different audiences
looking for different kinds of information.

Thanks,

jon
